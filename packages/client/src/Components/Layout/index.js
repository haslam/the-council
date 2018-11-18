import React from 'react';
import styles from './index.module.css';

export default function Layout({ children }) {
  return (<header className="App-header">
    <div className={styles.grid}>
      {children}
    </div>
  </header>);
}
