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
        <title>Privacy | Planetaria</title>
        <meta name="viewport" content="initial-scale=1.0, width=device-width" />
      </Head>
      <Flex flexDirection="column" alignItems="center">
        <Header/>
        <br/><br/><br/><br/><br/><br/>

        <div className={styles.column}>
          
          <div className={styles.description}>

            <img className={styles.image} src="https://github.com/joerup2004/planetaria/blob/main/Images/PlanetariaClear.png?raw=true"/>
            <h1 className={styles.title}>Privacy Policy</h1>

            <h4 className={styles.title2}>Last updated June 26, 2021</h4>
            <p>
            <br/>
            Thank you for choosing to be part of our community at Planetaria ("Company", "we", "us", "our"). We are committed to protecting your personal information and your right to privacy. 

            <b> By using Planetaria, you are consenting to our policies regarding the collection, use and disclosure of personal information set out in this privacy policy. </b>

            We hope you take some time to read through it carefully, as it is important. If there are any terms in this privacy notice that you do not agree with, please discontinue use of our Services immediately.

            This privacy notice applies to all information collected through our Services (which includes our App and Website), as well as, any related services, sales, marketing or events.
            <br/><br/>
            </p>
            <h3 className={styles.title2}>What information do we collect?</h3>
            <p>
            <b>None. We don't collect your data, period. </b> 

            There literally is nothing for us to store. You physically can't even put any data into Planetaria in the first place, except searching for something.

            We do not transfer your data to any other location, nor do we include any advertising or analytics software affiliated with third parties.
            <br/><br/>
            </p>
            <h3 className={styles.title2}>Do we update this privacy policy?</h3>
            <p>
            <b>We may update this privacy notice as necessary to stay compliant with relevant laws. </b> 

            The updated version will be indicated by the "last updated" date and the updated version will be effective as soon as it is accessible. 

            If we make material changes to this privacy notice, we may notify you either by posting a notice of such changes or by directly sending you a notification. 

            We encourage you to review this privacy notice frequently to be informed of how we are protecting your information.
            <br/><br/>
            </p>
            <h3 className={styles.title2}>How can you contact us about this policy?</h3>
            <p>
            <b>If you have questions, comments, or concerns about Planetaria's privacy policy, please do not hesitate to reach out. </b>
                
            You can contact us on our <Link href="/support"><a>Support page</a></Link>.
            </p>
            <br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/><br/>
          </div>
        </div>
        
        <br/><br/><br/><br/><br/><br/>
        <Footer/>
      </Flex>
    </Box>
  )
}
