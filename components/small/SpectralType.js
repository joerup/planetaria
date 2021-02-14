import React from 'react'
import { default as NextLink } from 'next/link'
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import styles from '../../styles/object.module.css'

export default function SpectralType(props) {
  if (props.type != null) {
    return `Spectral Class: ${props.type}`;
  }
  return null;
}