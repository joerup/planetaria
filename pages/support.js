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
        <title>Support | Planetaria</title>
        <meta name="viewport" content="initial-scale=1.0, width=device-width" />
      </Head>
      <Flex flexDirection="column" alignItems="center">
        <Header/>
        <br/><br/><br/><br/><br/><br/>

        <div className={styles.column}>
          
          <div className={styles.description}>

            <img className={styles.image} src="https://github.com/joerup2004/planetaria/blob/main/Images/PlanetariaClear.png?raw=true"/>
            <h1 className={styles.title}>Support and Feedback</h1>
            
            <br/>
            <p className={styles.desc}>Thank you for wishing to contact us at Planetaria.</p>
            <h3 className={styles.title2}><b>Email Contact:<br/>rupertusapps@gmail.com</b></h3>
            <br/>
            <br/>
            <h3 className={styles.title2}>Questions</h3>
            <p>If you have a question, please send an email to the address listed above, providing as much detail as possible.</p>
            <br/>
            <h3 className={styles.title2}>Feedback</h3>
            <p>Please send any feedback to our email address listed above. We appreciate your willingness to provide us with details to make our app even better for everyone.</p>
            <br/>
            <h3 className={styles.title2}>Bug Reports</h3>
            <p>If you wish to notify us of a bug or unknown behavior in the app, please do not hesitate to contact us by email. In your message, please provide as much detail as possible, including:</p>
            <li>Device and iOS Version</li>
            <li>Planetaria Version</li>
            <li>Steps to reproduce issue</li>
            <br/>
            <p>If you wish to notify us of a bug or unknown behavior in the website, please include:</p>
            <li>Date of Occurrence</li>
            <li>Steps to reproduce issue</li>
            <br/>
            <br/>
            <br/>
            <br/>
          </div>
        </div>
        
        <br/><br/><br/><br/><br/><br/>
        <Footer/>
      </Flex>
    </Box>
  )
}
