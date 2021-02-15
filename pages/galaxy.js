import NextLink from "next/link";
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import Head from 'next/head';
import { NextPage } from "next";
import styles from '../styles/list.module.css';
import Header from '../components/Header.js';
import Footer from '../components/Footer.js';
import ObjectRow from '../components/ObjectRow.js';
import { getStarSystems } from "../components/helpers.js";

export default function Galaxy(props) {
  return (
    <Box className={styles.background}>
      <Head>
        <title>Milky Way Galaxy | Planetaria</title>
        <meta name="viewport" content="initial-scale=1.0, width=device-width" />
      </Head>
      <Flex flexDirection="column" alignItems="center">
        <Header/>
        <br/><br/><br/><br/>

        <div class={styles.top}> 
          <div class={styles.headline}>
            <div class={styles.tophorizontal}>
              <Link href="javascript:history.back()">
                <img src="https://github.com/joerup2004/planetaria/blob/main/Images/whitechevron.png?raw=true" width="100" height="100"/>
              </Link>
              <div className={styles.toptext}>
                <div class={styles.bigobjecttitle}>Milky Way Galaxy</div>
                <p class={styles.bigobjectdesc}>Our Stellar Neighborhood</p>
              </div>
              <img className={styles.bigobjectimage} src={`https://github.com/joerup2004/planetaria/blob/main/Images/Objects/MilkyWay.png?raw=true`}/>
            </div>
          </div>
        </div>

        {props.systems.map(system => {
          if(system.stars.length == 1 && system.planets.length == 0 && system.name != "Solar System") {
            return (
              <ObjectRow 
                as={`/stars/${system.stars[0].name}`} 
                href={`/stars/[id]`}
                key={`/stars/${system.stars[0].name}`} 
                image={system.stars[0].image} 
                name={system.name} 
                desc={system.desc}
              />
            )
          }
          return (
            <ObjectRow 
              as={system.name == "Solar System" ? `/solarsystem` : `/systems/${system.name}`} 
              href={system.name == "Solar System" ? `/solarsystem` : `/systems/[id]`}
              key={system.name == "Solar System" ? `/solarsystem` : `/systems/${system.name}`} 
              image={system.stars[0].image} 
              name={system.name} 
              desc={system.name == "Solar System" ? "Our Planetary Neighborhood" : system.desc}
            />
          )
        })}

        <Footer/>
      </Flex>
    </Box>
  )
}

export async function getStaticProps({ params }) {
  const json = await fetch("https://raw.githubusercontent.com/joerup2004/planetaria/main/objects1.json");
  const bodies = await json.json();
  const { stars, planets } = bodies;

  var systems = getStarSystems(stars, planets);

  return {
    props: {
      systems
    }
  };
}
