import { useRouter } from "next/router";
import NextLink from "next/link";
import Head from 'next/head';
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import { NextPage } from "next";
import styles from '../../../styles/list.module.css'
import Header from '../../../components/Header.js';
import Footer from '../../../components/Footer.js';
import ObjectRow from '../../../components/ObjectRow.js';
import { getMoons } from "../../../components/helpers.js";

export default function MoonList({ planet, moons }) {
  const router = useRouter();
  const { id } = router.query;

  return (
    <Box className={styles.background}>
      <Head>
        <title>{planet.adjective != null ? planet.adjective : planet.name} Moons | Planetaria</title>
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
                <div class={styles.bigobjecttitle}>{planet.adjective != null ? planet.adjective : planet.name} Moons</div>
                <p class={styles.bigobjectdesc}>{planet.name}'s {planet.moons} Moons</p>
              </div>
              <img className={styles.bigobjectimage} src={`https://github.com/joerup2004/planetaria/blob/main/Images/Objects/${planet.image != null ? planet.image : "Unknown"}.png?raw=true`}/>
            </div>
          </div>
        </div>

        {moons.map(moon => {
          return (
            <ObjectRow 
              as={`/moons/${moon.name}`} 
              href="/moons/[id]" 
              key={`/moons/${moon.name}`} 
              image={moon.image} 
              name={moon.name} 
              desc={moon.altName3 != null ? `${moon.orbiting} ${moon.altName3}` : ''}
            />
          )
        })}

        <Footer/>
      </Flex>
    </Box>
  )
}

export async function getStaticPaths() {
  const json = await fetch("https://raw.githubusercontent.com/joerup2004/planetaria/main/objects1.json");
  const bodies = await json.json();
  const paths = bodies.planets.map(planet => ({
    params: { id: planet.name.toString() }
  }));

  return {
    paths,
    fallback: false
  };
}

export async function getStaticProps({ params }) {
  const json = await fetch("https://raw.githubusercontent.com/joerup2004/planetaria/main/objects1.json");
  const bodies = await json.json();
  const { planets, moons } = bodies;

  let planet = planets.find(planet => planet.name == params.id)
  
  return {
    props: {
      planet: planet,
      moons: getMoons(planet, moons)
    }
  };
}