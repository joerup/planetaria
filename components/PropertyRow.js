import React from 'react'
import { default as NextLink } from 'next/link'
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import styles from '../styles/object.module.css'

export default function PropertyRow(props) {
  var data = props.data;
  var unit = props.unit;
  if (data == null) return null;

  if (props.cutoff != null && Math.abs(data) >= props.cutoff) {
    data /= props.divide;
    unit = props.unit2;
  }
  else if (props.cutoff2 != null && Math.abs(data)*props.mult < props.cutoff2) {
    data *= props.mult;
    unit = props.unit3;
  }

  if (typeof(data) == "number") {
    let vector = props.vector == null ? null : props.vector == "true" ? true : false;
    let digits = props.sf == null ? 3 : props.sf;
    data = format(data, vector, digits);
  }
  let row = (
    <div className={styles.propertyRow}>
      <div className={styles.propertyName}>{props.name}</div>
      <div className={styles.property}>{data}{unit}</div>
    </div>
  );
  return row;
}


function format(num, vector, digits) {
  
  var number = num;

  // sig figs
  function sf(num) {
    let sf = getSF(num);
    if (sf > digits) {
      num = Number.parseFloat(num).toPrecision(digits);
      num = String(Number(num))
    }
    return num;
  }
  function getSF(num) {
    if (!isFinite(Number(num))) {
      return -1;
    }
    var n = String(num).trim(),
    FIND_FRONT_ZEROS_SIGN_DOT_EXP = /^[\D0]+|\.|([e][^e]+)$/g,
    FIND_RIGHT_ZEROS = /0+$/g;
   
    if (!/\./.test(num)) {
      n = n.replace(FIND_RIGHT_ZEROS, "");
    }
    return n.replace(FIND_FRONT_ZEROS_SIGN_DOT_EXP, "").length;
  };

  number = sf(number);

  if(number == null) return null;

  // add commas
  var string = number.toString();
  if (!string.includes(",")) {
    var index = string.length-3;
    if (string.includes(".")) {
      index = string.indexOf(".")-3;
    }
    while (index > 0) {
      if (!(string.charAt(0) == "-" && index == 1)) {
        string = string.substr(0,index) + "," + string.substr(index)
      }
      index -= 3;
    }
  }

  // scientific notation
  // greater than 10^8, less than 10^-4 && greater than 0
  if (num > Math.pow(10,8)) {
      let power = Math.floor(Math.log(num)/Math.log(10));
      let base = sf(num/(Math.pow(10,power)));
      string = base+"×10^"+parseInt(power);
  }
  if (num < Math.pow(10,-4) && num > 0) {
      let power = Math.floor(Math.log(num)/Math.log(10));
      let base = sf(num/(Math.pow(10,power)));
      string = base+"×10^"+parseInt(power);
  }

  if(vector && num > 0) {
    string = "+" + string;
  }
  else if(!vector && vector != null && string.charAt(0) == "-") {
    string = string.substr(1);
  }

  return string;
}