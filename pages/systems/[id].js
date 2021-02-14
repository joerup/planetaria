import { useRouter } from "next/router";
import NextLink from "next/link";
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import { NextPage } from "next";
import styles from '../../styles/list.module.css';
import Header from '../../components/Header.js';
import Footer from '../../components/Footer.js';
import ObjectRow from '../../components/ObjectRow.js';
import SolarSystem from "../galaxy";
import { getStarSystems, starDesc, systemDesc } from "../../components/helpers.js";

export default function StarSystem({ system }) {
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
                <div class={styles.bigobjecttitle}>{system.name}</div>
                <p class={styles.bigobjectdesc}>{system.desc}</p>
              </div>
              <img className={styles.bigobjectimage} src={`https://github.com/joerup2004/planetaria/blob/main/Images/Objects/${system.stars[0].image != null ? system.stars[0].image : "Unknown"}.png?raw=true`}/>
            </div>
            <p class={styles.paragraph}>{system.stars[0].systemParagraph}</p>
          </div>
        </div>

        {system.stars.map(star => {
          return (
            <ObjectRow 
              as={`/stars/${star.name}`} 
              href={`/stars/[id]`}
              key={`/stars/${star.name}`} 
              image={star.image} 
              name={star.name} 
              desc={star.desc != null ? star.desc : starDesc(star)}
            />
          )
        })}

        <p className={styles.section} className={styles.section}>{system.planets.length > 0 ? 'Planets' : ''}</p>
        {system.planets.map(planet => {
          return (
            <ObjectRow 
              as={`/planets/${planet.name}`} 
              href={`/planets/[id]`}
              key={`/planets/${planet.name}`} 
              image={planet.image} 
              name={planet.name} 
              desc={planet.desc}
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
  const paths = getStarSystems(bodies.stars, bodies.planets).map(system => ({
    params: { id: system.name.toString() }
  }));

  return {
    paths,
    fallback: false
  };
}

export async function getStaticProps({ params }) {
  const json = await fetch("https://raw.githubusercontent.com/joerup2004/planetaria/main/objects1.json");
  const bodies = await json.json();
  const { stars, planets } = bodies;

  let starSystems = getStarSystems(stars, planets);
  
  return {
    props: {
      system: starSystems.find(system => system.name == params.id)
    }
  };
}