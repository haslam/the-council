import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { Card, Icon } from 'semantic-ui-react'
import Layout from '../../Components/Layout';
import Avatar from '../../Components/Avatar';
import UserCard from '../../Components/UserCard';

PropTypes.shape({
  trust: PropTypes.number.isRequired,
  isBlacklisted: PropTypes.bool.isRequiried,
  authority: PropTypes.object,
});

export default function Users({ match }) {
  const [targetUser, setTargetUser] = useState(null);

  useEffect(() => {
    console.log('Fetching user based on ', match.params.hash);
    setTimeout(() => setTargetUser({
      username: 'User Loaded Maybe',
      avatar: <Avatar hash={match.params.hash} />,
    }), 3000);
  }, [match.params.hash]);

  console.log('match ', match.params.id);

  return (
    <Layout>
      <UserCard hash={match.params.hash}/>
    </Layout>);
}
