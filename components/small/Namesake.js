import React from 'react'
import { default as NextLink } from 'next/link'
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import styles from '../../styles/object.module.css'

export default function Namesake(props) {
  if (props.namesake != null && props.nameReason != null) {
    return `Named after ${props.namesake} because ${props.nameReason}`;
  }
  else if (props.namesake != null) {
    return `Named after ${props.namesake}`;
  }
  return null;
}