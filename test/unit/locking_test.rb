require 'ostruct'
require 'foreman_tasks_test_helper'

module ForemanTasks
  class LockTest < ::ActiveSupport::TestCase
    describe ::ForemanTasks::Lock::LockConflict do
      class FakeLockConflict < ForemanTasks::Lock::LockConflict
        def _(val)
          val.freeze
        end
      end

      it 'does not modify frozen strings' do
        required_lock = OpenStruct.new(:name => 'my_lock')
        # Before #21770 the next line would raise
        #   RuntimeError: can't modify frozen String
        conflict = FakeLockConflict.new(required_lock, [])
        assert conflict._('this should be frozen').frozen?
      end
    end

    describe 'locking and linking' do
      before { [Lock, Link].each(&:destroy_all) }
      let(:task1) { FactoryBot.create(:some_task) }
      let(:task2) { FactoryBot.create(:some_task) }
      let(:resource) { FactoryBot.create(:user) }

      describe Lock do
        it 'can lock a resource for a single task' do
          Lock.lock!(resource, task1)
        end

        it 'can lock a resource for a single task only once' do
          Lock.lock!(resource, task1)
          _(Lock.for_resource(resource).count).must_equal 1
          Lock.lock!(resource, task1)
          _(Lock.for_resource(resource).count).must_equal 1
        end

        it 'cannot lock a resource for multiple tasks' do
          lock = Lock.lock!(resource, task1)
          _(Lock.colliding_locks(resource, task2)).must_equal [lock]
          assert_raises Lock::LockConflict do
            Lock.lock!(resource, task2)
          end
        end

        it 'raises LockConflict when enforced by db' do
          lock = Lock.lock!(resource, task1)
          Lock.any_instance
              .expects(:colliding_locks).twice.returns([], [lock])
          exception = assert_raises Lock::LockConflict do
            Lock.lock!(resource, task2)
          end
          _(exception.message).must_match(/#{lock.task_id}/)
        end

        it 'creates a link when creating a lock for a resource' do
          Lock.lock!(resource, task1)
          link = Link.for_resource(resource).first
          _(link.task_id).must_equal task1.id
        end
      end

      describe Link do
        it 'can link a resource to a single task' do
          Link.link!(resource, task1)
        end

        it 'can link a resource for a single task only once' do
          Link.link!(resource, task1)
          _(Link.for_resource(resource).count).must_equal 1
          Link.link!(resource, task1)
          _(Link.for_resource(resource).count).must_equal 1
        end

        it 'can link a resource to multiple tasks' do
          Link.link!(resource, task1)
          Link.link!(resource, task2)
          _(Link.for_resource(resource).count).must_equal 2
        end
      end
    end
  end
end
