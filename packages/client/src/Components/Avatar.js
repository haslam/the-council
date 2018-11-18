import React, { useEffect, useState } from 'react';
import generateNewIdenticon from '../lib/jazzicon';

export default function Avatar({ hash }) {
  const [id] = useState(() => Math.floor(Math.random() * 10000000).toString());

  useEffect(() => {
    const dimension = 290;
    console.log('Fetching user based on ', hash);
    const ref = document.getElementById(id);
    const svg = generateNewIdenticon(hash, 290);
    [...svg.children].forEach(svgElement => {
      if (svgElement.hasAttribute('width') && svgElement.getAttribute('width') !== dimension) {
        svgElement.setAttribute('width', dimension);
      }
      if (svgElement.hasAttribute('height') && svgElement.getAttribute('height') !== dimension) {
        svgElement.setAttribute('height', dimension);
      }
    });
    ref.appendChild(svg);

    return () => {
      ref.removeChild(svg);
    }
  }, [hash]);

  return (
    <div className='ui medium image' id={id} />);
}
