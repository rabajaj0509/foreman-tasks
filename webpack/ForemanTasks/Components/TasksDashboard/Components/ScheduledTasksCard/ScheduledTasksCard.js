import React from 'react';
import PropTypes from 'prop-types';
import { Card, Icon } from 'patternfly-react';
import classNames from 'classnames';
import { translate as __ } from 'foremanReact/common/I18n';
import './ScheduledTasksCard.scss';

const ScheduledTasksCard = ({ className, scheduled, focusedOn, onClick }) => (
  <Card
    className={classNames(
      'tasks-donut-card',
      'scheduled-tasks-card',
      className,
      {
        'selected-tasks-card': focusedOn && focusedOn.total,
      }
    )}
  >
    <Card.Title onClick={onClick}>{__('Scheduled')}</Card.Title>
    <Card.Body>
      <div
        className={classNames('scheduled-data', {
          'not-focused': !(focusedOn && (focusedOn.total || focusedOn.normal)),
        })}
        onClick={onClick}
      >
        {scheduled}
        <Icon type="fa" name="clock-o" />
      </div>
    </Card.Body>
  </Card>
);

ScheduledTasksCard.propTypes = {
  scheduled: PropTypes.number.isRequired,
  onClick: PropTypes.func.isRequired,
  className: PropTypes.string,
  focusedOn: PropTypes.shape({ total: PropTypes.bool, normal: PropTypes.bool }),
};

ScheduledTasksCard.defaultProps = {
  className: '',
  focusedOn: {},
};

export default ScheduledTasksCard;