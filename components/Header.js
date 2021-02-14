import React from 'react'
import { default as NextLink } from 'next/link'
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import styles from '../styles/headfoot.module.css'

export default function Header({ props }) {
  return(
    <header className={styles.navbar}>
      <NextLink href="../">
        <Link>
          <div className={styles.navleft}>
            <img className={styles.logo} src="https://github.com/joerup2004/planetaria/blob/main/Images/PlanetariaClear.png?raw=true"/>
            <p className={styles.title}>Planetaria</p>
          </div>
        </Link>
      </NextLink>

      <div className={styles.navright}>

        <div className={styles.search}>
          <div className={styles.searchBar}>
            <NextLink href="../search">
              <Link>
                <p className={styles.searchTitle}>Search</p>
              </Link>
            </NextLink>
          </div>
        </div>

        <div className={styles.dropdown}>
          <img className={styles.dropbutton} src="https://img.icons8.com/metro/26/ffffff/menu.png"/>
          <div className={styles.dropdowncontent}>
            <a href="../solarsystem">System</a>
            <a href="../galaxy">Galaxy</a>
            <a href="../about">About</a>
            <a href="https://apps.apple.com/is/app/planetaria/id1546887479">App</a>
          </div>
        </div>

        <NextLink href="../solarsystem">
          <Link><p className={styles.rowItem}>System</p></Link>
        </NextLink>
        <NextLink href="../galaxy">
          <Link><p className={styles.rowItem}>Galaxy</p></Link>
        </NextLink>
        <NextLink href="../about">
          <Link><p className={styles.rowItem}>About</p></Link>
        </NextLink>
        <a href="https://apps.apple.com/is/app/planetaria/id1546887479"><p className={styles.rowItem}>App</p></a>
        
      </div>

      

    </header>
  )
}