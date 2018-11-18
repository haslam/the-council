import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { getCurrentAccount } from 'ethwrapper';

import styles from './index.module.css';

import SearchBar from '../SearchBar';

export default function menuBar({ className }) {
  const [userID, setUserID] = useState('');

  useEffect(() => {
    const id = getCurrentAccount();
    setUserID(id);
  });

  return (
    <span className={`${className} ${styles.menuBarGray}`}>
      <span className={styles.padFifteen}>
        <Link
          className={`ui button`}
          disabled={!!userID}
          to={`/users/${userID}`}
          type='submit'
        >
          Open My User
        </Link>
      </span>
      <span className={styles.padFifteen}>
        <SearchBar />
      </span>
    </span>
  );
}
