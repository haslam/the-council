// @flow

import React, { useState, useEffect } from 'react';
import { Route, Switch } from 'react-router-dom';
import './App.css';
import Index from './Pages/Index';
import Users from './Pages/Users';
import About from './Pages/About';
import ethwrapper from 'ethwrapper';
import NotFound from './Pages/NotFound';

console.log(ethwrapper);

function App() {
  const [isLoaded, setLoaded] = useState(false);
  const [isErrored, setErrored] = useState(false);

  if (isErrored) {
    window.open('https://blog.wetrust.io/how-to-install-and-use-metamask-7210720ca047', '_blank');
  }

  useEffect(() => {
    if (!isLoaded && !isErrored) {
      ethwrapper.load().then(() => setLoaded(true)).catch(setErrored);
    }
  });

  console.log('rendering App');

  if (isErrored) {
    return (<div className="App">
      Waiting for MetaMask to be installed...
      </div>)
  }

  return (
    <div className="App">
      {isLoaded
        ? (<Switch>
          <Route exact path='/' component={Index} />
          <Route exact path='/users/:hash' component={Users} />
          <Route exact path='/about' component={About} />
          <Route component={NotFound} />
        </Switch>)
        : "Loading..."}
    </div>
  );
}

export default App;
