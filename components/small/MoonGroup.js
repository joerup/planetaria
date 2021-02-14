import React from 'react'
import { default as NextLink } from 'next/link'
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import styles from '../../styles/object.module.css'

export default function MoonGroup(props) {
  if (props.group != null) {
    return `Group: ${props.group} moons`;
  }
  return null;
}