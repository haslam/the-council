import React from 'react';
import Layout from '../../Components/Layout';

import styles from './index.module.css';

export default function About() {
  return (
    <Layout>
      <div className={styles.body}>
        <h2>About</h2>
        <p>
          This is a page about trust.
          As a new user you must get someone in the network to trust you.
        </p>
      </div>
    </Layout>);
}
