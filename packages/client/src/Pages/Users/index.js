import React, { useEffect, useState } from 'react';
import PropTypes from 'prop-types';
import { Item } from 'semantic-ui-react';

import styles from './index.module.css';
import Layout from '../../Components/Layout';
import Avatar from '../../Components/Avatar';
import UserCard from '../../Components/UserCard';

PropTypes.shape({
  trust: PropTypes.number.isRequired,
  isBlacklisted: PropTypes.bool.isRequiried,
  authority: PropTypes.object,
});

export default function Users({ match }) {
  return (
    <Layout>
      <Item.Group className={styles.greyBackground}>
        <UserCard hash={match.params.hash} />
      </Item.Group>
    </Layout>);
}
