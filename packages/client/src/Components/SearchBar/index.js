import React, { useState } from 'react';
import { Link, Redirect } from 'react-router-dom';
import { Button, Input } from 'semantic-ui-react';

export default function SearchBar() {
  const [query, setQuery] = useState('');

  const updateValue = (event) => {
    setQuery(event.target.value);
  };

  return (
    <>
      <Input
        type='text'
        value={query}
        onChange={updateValue}
        placeholder='0x0000000000000000000000000000000000000000'
        action
      >
        <input />
        <Link
          className="ui button"
          disabled={query !== ''}
          to={`/users/${query}`}
          type='submit'
        >
          Open
        </Link>
      </Input>
    </>);
}
