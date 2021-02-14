import React from 'react'
import { default as NextLink } from 'next/link'
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import styles from '../styles/list.module.css'

export default function ObjectRow(props) {
  return (
    <NextLink 
      as={props.as}
      href={props.href}
      passHref
      key={props.key}
    >
      <div className={styles.row}>
        <Link>
          <div className={styles.objectrow}>
            <img className={styles.objectimage} src={`https://github.com/joerup2004/planetaria/blob/main/Images/Objects/${props.image != null ? props.image : "Unknown"}.png?raw=true`}/>  
            <div>
              <p className={styles.objecttitle}> {props.name} </p>
              <p className={styles.objectdesc}> {props.desc} </p>
            </div>
          </div>
        </Link>
      </div>
    </NextLink>
  )
}