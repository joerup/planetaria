import React from 'react'
import { default as NextLink } from 'next/link'
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import styles from '../../styles/object.module.css'

export default function Discovery(props) {
  if (props.discoveryDate != null && props.discoveredBy != null) {
    return `Discovered in ${props.discoveryDate} by ${props.discoveredBy}`;
  }
  else if (props.discoveryDate != null) {
    return `Discovered in ${props.discoveryDate}`;
  }
  return null;
}