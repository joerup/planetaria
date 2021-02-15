import React from 'react'
import { default as NextLink } from 'next/link'
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import styles from '../styles/list.module.css'

export default function ObjectRow(props) {
  if(props.object == null || props.object == false) {
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
              <div className={styles.objecttitle}>
                { props.name.length > 16 ? <h3>{props.name}</h3> : props.name.length > 12 ? <h2>{props.name}</h2> : <h1>{props.name}</h1> }
                <p>{props.desc}</p>
              </div>
            </div>
          </Link>
        </div>
      </NextLink>
    )
  }
  return (
    <NextLink 
      as={props.as}
      href={props.href}
      passHref
      key={props.key}
    >
      <div className={styles.row}>
        <Link>
          <div className={styles.objectrow2}>
            <img className={styles.objectimage} src={`https://github.com/joerup2004/planetaria/blob/main/Images/Objects/${props.image != null ? props.image : "Unknown"}.png?raw=true`}/>  
            <div className={styles.objecttitle}>
              { props.name.length > 16 ? <h3>{props.name}</h3> : props.name.length > 14 ? <h2>{props.name}</h2> : <h1>{props.name}</h1> }        
              <p>{props.desc}</p>
            </div>
          </div>
        </Link>
      </div>
    </NextLink>
  )
}