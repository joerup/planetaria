import { useRouter } from "next/router";
import NextLink from "next/link";
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import { NextPage } from "next";
import styles from '../../../styles/list.module.css'
import Header from '../../../components/Header.js';
import Footer from '../../../components/Footer.js';
import ObjectRow from '../../../components/ObjectRow.js';

export default function DwarfMoonList({ moons }) {
  const router = useRouter();
  const { id } = router.query;

  return (
    <Box className={styles.background}>
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
                <div class={styles.bigobjecttitle}>Dwarf Moons</div>
                <p class={styles.bigobjectdesc}>Moons of the Dwarf Planets</p>
              </div>
              <img className={styles.bigobjectimage} src={`https://github.com/joerup2004/planetaria/blob/main/Images/Objects/Pluto.png?raw=true`}/>
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
  const json = await fetch("https://raw.githubusercontent.com/joerup2004/planetaria/main/objects.json");
  const bodies = await json.json();
  const paths = ["/moons/moonlist/Dwarf"]

  return {
    paths,
    fallback: false
  };
}

export async function getStaticProps({ params }) {
  const json = await fetch("https://raw.githubusercontent.com/joerup2004/planetaria/main/objects.json");
  const bodies = await json.json();
  const { planets, moons } = bodies;

  var dwarfplanets = [];
  planets.map(planet => {
    if(planet.type == "Dwarf Planet") {
      dwarfplanets.push(planet.name);
    }
  })
  var dwarfmoons = [];
  moons.map(moon => {
    if(dwarfplanets.includes(moon.orbiting)) {
      dwarfmoons.push(moon)
    }
  })

  return {
    props: {
      moons: dwarfmoons
    }
  };
}