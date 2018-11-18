import React from 'react';
import styles from './index.module.css';
import MenuBar from '../MenuBar';

export default function Layout({ children }) {
  return (
    <div className={styles.grid}>
      <MenuBar className={styles.gridMenu} />
      <div className={styles.gridDisplay}>
        {children}
      </div>
    </div>
  );
}
