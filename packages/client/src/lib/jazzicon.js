import jazzicon from 'jazzicon'

function generateNewIdenticon(address, diameter) {
  return jazzicon(diameter, jsNumberForAddress(address));
}

function jsNumberForAddress (address) {
  console.log(address);
  return parseInt(address.slice(2, 10), 16);
}

export default generateNewIdenticon;
