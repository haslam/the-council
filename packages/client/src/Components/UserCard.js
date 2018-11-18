import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { Icon, Item, Divider } from 'semantic-ui-react'
import Avatar from '../Components/Avatar';
import UpdateXButton from './UpdateXButton';
import { getCurrentAccount, getTrustData, markUser, unmarkUser, vouchForUser, unVouchForUser } from 'ethwrapper';

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

  return (<Item>
    {targetUser ? targetUser.avatar : <Item.Image size="medium" />}
    <Item.Content>
      <Item.Header style={{ wordWrap: 'break-word' }}>
        {targetUser ? targetUser.hash : 'Loading...'}
      </Item.Header>
      <Item.Extra>
        <a>
          <Icon name='user' />
          Trust Ranking {targetUser ? targetUser.trustLevel : 'Loading...'}
        </a>
        <br />
        <a>
          <Icon name='user' />
          {targetUser ? (targetUser.blacklisted ? 'Blacklisted' : 'Not Blacklisted') : 'Loading...'}
        </a>
        <Divider />
        {targetUser
          ? <>
            <UpdateXButton user={targetUser} executor={vouchForUser} text="Add Trust" />
            <UpdateXButton user={targetUser} executor={unVouchForUser} text="Remove Trust" />
            <UpdateXButton user={targetUser} executor={markUser} text="Blacklist User" />
            <UpdateXButton user={targetUser} executor={unmarkUser} text="UnBlacklist User" />
          </>
          : ''}
      </Item.Extra>
    </Item.Content>
  </Item>);
}
