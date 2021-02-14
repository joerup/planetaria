import { useRouter } from "next/router";
import NextLink from "next/link";
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import { NextPage } from "next";
import styles from '../../styles/list.module.css'
import Header from '../../components/Header.js';
import Footer from '../../components/Footer.js';
import ObjectRow from '../../components/ObjectRow.js';

export default function Asteroids({ asteroids }) {
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
                <div class={styles.bigobjecttitle}>Asteroids</div>
                <p class={styles.bigobjectdesc}>Small rocky bodies orbiting the Sun</p>
              </div>
              <img className={styles.bigobjectimage} src={`https://github.com/joerup2004/planetaria/blob/main/Images/Objects/${asteroids[2].image}.png?raw=true`}/>
            </div>
            <p class={styles.paragraph}>Asteroids are small rocky objects that orbit the Sun in the inner Solar System. Most are found between Mars and Jupiter in a region known as the Asteroid Belt. Some asteroids cross beyond the Belt and ocassionally cross Earth's orbit; these are constantly tracked to detect any possibility of a collision. Most asteroids are leftover rocks from the formation of the Solar System which did not manage to form a larger object, likely due to the gravitational influence of nearby Jupiter.</p>
          </div>
        </div>

        {asteroids.map(asteroid => {
          return (
            <ObjectRow 
              as={`/objects/${asteroid.name}`} 
              href="/objects/[id]" 
              key={`/objects/${asteroid.name}`} 
              image={asteroid.image} 
              name={asteroid.name} 
              desc={`#${asteroid.asteroidNumber}`} 
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
  const { other } = bodies;

  var asteroids = [];
  other.map(object => {
    if(object.type == "Asteroid") {
      asteroids.push(object);
    }
  })

  return {
    props: {
      asteroids: asteroids
    }
  };
}