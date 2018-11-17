// @flow

import React, { Component } from 'react';
import { Switch, Route } from 'react-router-dom';
import logo from './logo.svg';
import './App.css';
import Index from './Pages/Index';

class App extends Component {
  render() {
    return (
      <div className="App">
        <Switch>
          <Route exact path='/' component={Index} />
          <Route exact path='/users/' component={Index} />
        </Switch>
      </div>
    );
  }
}

export default App;