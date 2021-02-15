import NextLink from "next/link";
import Head from 'next/head';
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import { NextPage } from "next";
import styles from '../styles/title.module.css';
import Header from '../components/Header.js';
import Footer from '../components/Footer.js';

export default function About(props) {
  return (
    <Box className={styles.background}>
      <Head>
        <title>About | Planetaria</title>
        <meta name="viewport" content="initial-scale=1.0, width=device-width" />
      </Head>
      <Flex flexDirection="column" alignItems="center">
        <Header/>
        <br/><br/><br/><br/><br/><br/>

        <div class={styles.column}>
          <img className={styles.image} src="https://github.com/joerup2004/planetaria/blob/main/Images/PlanetariaClear.png?raw=true"/>
                      
          <h1 className={styles.title}>Planetaria</h1>
          
          <p className={styles.desc}>There is so much to explore in space: from the smallest comets that orbit the Sun every couple thousand years, to the planets that crown the Solar System, and the enormous stars seen from hundreds of light years away. Planetaria is a cumulative catalog of the astronomical objects in the Solar System and the Galaxy. Explore our local objects: the Sun, the eight planets, the dwarf planets, over two hundred moons, as well as small bodies like asteroids and comets. And now, explore beyond our system to find hundreds of stars and exoplanets waiting for discovery. See their stories, their beauty, their characteristics, and their impact. The universe is waiting to be explored with Planetaria.</p>
          
          <p className={styles.title2}>Download on the App Store</p>
          <p className={styles.desc2}>
            <a href="https://apps.apple.com/is/app/planetaria/id1546887479"><u>Planetaria App</u></a>
          </p>
          
          <p className={styles.title2}>Contact</p>
          <p className={styles.desc2}>rupertusapps@gmail.com</p>
        </div>
        
        <br/><br/><br/><br/><br/><br/>
        <Footer/>
      </Flex>
    </Box>
  )
}
