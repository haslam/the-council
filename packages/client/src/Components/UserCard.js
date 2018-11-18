import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { Card, Icon } from 'semantic-ui-react'
import { getTrustData } from 'ethwrapper';
import Avatar from '../Components/Avatar';

PropTypes.shape({
  trust: PropTypes.number.isRequired,
  isBlacklisted: PropTypes.bool.isRequiried,
  authority: PropTypes.object,
});

export default function UserCard({ hash }) {
  const [targetUser, setTargetUser] = useState(null);

  useEffect(() => {

    console.log('Fetching user based on ', hash);
    getTrustData(hash).then((userData) => setTargetUser({
      hash: hash,
      trustLevel: userData.trustLevel.toString(),
      blacklisted: userData.blacklisted,
      avatar: <Avatar hash={hash} />,
    }));
  }, [hash]);

  return (<Card>
    {targetUser ? targetUser.avatar : ''}
    <Card.Content>
      <Card.Header style={{ wordWrap: 'break-word' }}>
        {targetUser ? targetUser.hash : 'Loading...'}
      </Card.Header>
    </Card.Content>
    <Card.Content extra>
      <a>
        <Icon name='user' />
        Trust Ranking {targetUser ? targetUser.trustLevel : 'Loading...'}
      </a>
      <br />
      <a>
        <Icon name='user' />
        {targetUser ? (targetUser.blacklisted ? 'Blacklisted' : 'Not Blacklisted') : 'Loading...'}
      </a>
    </Card.Content>
  </Card>);
}
