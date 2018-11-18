import React, { useState } from 'react';
import { Redirect } from 'react-router-dom';
import Layout from '../../Components/Layout';
import { Button, Input } from 'semantic-ui-react';

export default function Index() {
  const [query, setQuery] = useState('');
  const [redirect, setRedirect] = useState('');

  const updateValue = (event) => {
    setQuery(event.target.value);
  };

  const redirectToUser = () => {
    setRedirect(`/users/${query}`);
  };

  const submit = () => {
    redirectToUser();
  };

  const handleKeyPress = (e) => {
    if (e.charCode === 32 || e.charCode === 13) {
      // Prevent the default action to stop scrolling when space is pressed
      e.preventDefault();
    }
    if (e.charCode === 13) {
      redirectToUser();
      console.log('Button received click with keyboard')
    }
  };

  if (redirect) {
    return <Redirect to={redirect} />
  }

  return (
    <Layout>
      <div>
        <p>Input an address to adjust trust settings</p>
        <br />
        <Input onKeyPress={handleKeyPress} type='text' value={query} onChange={updateValue} placeholder='0x0000000000000000000000000000000000000000' action>
          <input />
          <Button onClick={submit} type='submit'>Open</Button>
        </Input>
      </div>
    </Layout>);
}
