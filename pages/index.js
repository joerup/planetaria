import NextLink from "next/link";
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import { NextPage } from "next";
import styles from '../styles/title.module.css';
import Header from '../components/Header.js';
import Footer from '../components/Footer.js';

export default function Home(props) {
  return (
    <Box className={styles.background}>
      <Flex flexDirection="column" alignItems="center">
        <Header/>
        <br/><br/><br/><br/><br/><br/>

        <img className={styles.image} src="https://github.com/joerup2004/planetaria/blob/main/Images/PlanetariaClear.png?raw=true"/>
        <h1 className={styles.title}>Welcome to Planetaria</h1>
        <h1 className={styles.title3}>Explore Space</h1>

        <br/><br/>
            
        <div className={styles.searchBar}>
          <NextLink href="../search">
            <Link>
              <p className={styles.searchTitle}>Search</p>
            </Link>
          </NextLink>
        </div>
        
        <br/>

        <div class={styles.linkDiv}>
            
          <NextLink href="../solarsystem">
            <Link>
              <div className={styles.linkBox}>
                <div className={styles.linkRect}>
                  <img class={styles.linkImage} src="https://github.com/joerup2004/planetaria/blob/main/Images/Objects/Sun.png?raw=true"/>
                  <p className={styles.linkTitle}>Explore the Solar System</p>
                </div>
              </div>
            </Link>
          </NextLink>

          <NextLink href="../galaxy">
            <Link>
              <div className={styles.linkBox}>
                <div className={styles.linkRect}>
                  <img class={styles.linkImage} src="https://github.com/joerup2004/planetaria/blob/main/Images/Objects/MilkyWay.png?raw=true"/>
                  <p className={styles.linkTitle}>Explore the Galaxy</p>
                </div>
              </div>
            </Link>
          </NextLink>

        </div>

        <br/><br/><br/><br/><br/>
        
        <Footer/>
      </Flex>
    </Box>
  )
}
