import React from 'react'
import { default as NextLink } from 'next/link'
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import styles from '../styles/headfoot.module.css'

export default function Footer({ props }) {
  return(
    <div className={styles.footer}>
      <br/><br/><br/>
      <p className={styles.finePrint}>
        Sources
        <br/>
        All data and information for astronomical objects obtained from NASA, Johnston Archive, Wikipedia. 
        Images of astronomical objects provided by NASA/Jet Propulsion Laboratory/Space Science Institute. 
        Images are the property of their respective organizations. NASA/JPL/SSI are not affiliated with Planetaria and they do not endorse it. 
        <br/>
        Links:
        <a href="https://nssdc.gsfc.nasa.gov/planetary/planetfact.html"><u> NASA Fact Sheets </u></a>
        –
        <a href="https://nssdc.gsfc.nasa.gov/planetary/"><u> NASA Planetary Science Page </u></a>
        –
        <a href="http://www.johnstonsarchive.net/astro/index.html"><u> Johnston's Archive </u></a>

        
      </p>

    </div>
  )
}




