// @flow

import React, { useEffect, useState } from 'react';
import { Button } from 'semantic-ui-react';

export default function UpdateXButton(
  {
    user: {
      hash,
      trustLevel,
      blacklisted,
      avatar,
    },
    executor,
    text,
  }) {

  const [buttonActionRunning, setButtonActionRunning] = useState(false);

  function onClick() {
    setButtonActionRunning(true);
    // unmarkUser(hash);
    executor(hash).then(() => {
      setButtonActionRunning(false);
    }).catch(alert);
  }

  return (<Button disabled={buttonActionRunning} onClick={onClick}>{text}</Button>);
}
