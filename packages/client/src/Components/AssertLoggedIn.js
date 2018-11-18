import React, { useEffect, useState } from 'react';
import { load, getCurrentAccount, getTrustData } from 'ethwrapper';

export default function AssertLoggedIn({ callback }) {
  const [user, setUser] = useState(null);
  const [error, setError] = useState(null);

  useEffect(() => {
    (async () => {
      try {
        console.log('Going to load');
        let hash = await getCurrentAccount();
        setUser(await getTrustData(hash));
        console.log('Loaded');
      } catch (err) {
        setError(err);
      }
    })();
  }, [callback]);

  console.log("user", user, error);

  return (callback(user, error));
}
