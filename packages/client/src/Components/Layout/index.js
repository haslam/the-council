import logo from '../../logo.svg';
import React from 'react';

export default function Layout({ children }) {
  return (<header className="App-header">
    <img src={logo} className="App-logo" alt="logo" />
    {children}
    <a
      className="App-link"
      href="https://reactjs.org"
      target="_blank"
      rel="noopener noreferrer"
    >
      Learn React
    </a>
  </header>);
}
