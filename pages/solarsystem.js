import NextLink from "next/link";
import Head from 'next/head';
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import { NextPage } from "next";
import styles from '../styles/list.module.css';
import Header from '../components/Header.js';
import Footer from '../components/Footer.js';
import ObjectRow from '../components/ObjectRow.js';

export default function SolarSystem(props) {
  return (
    <Box className={styles.background}>
      <Head>
        <title>Solar System | Planetaria</title>
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
                <div class={styles.bigobjecttitle}>Solar System</div>
                <p class={styles.bigobjectdesc}>Our Planetary Neighborhood</p>
              </div>
              <img className={styles.bigobjectimage} src={`https://github.com/joerup2004/planetaria/blob/main/Images/Objects/Sun.png?raw=true`}/>
            </div>
          </div>
        </div>

        <ObjectRow 
          as={`/stars/${props.stars[0].name}`} 
          href="/stars/[id]" 
          key={`/stars/${props.stars[0].name}`} 
          image={props.stars[0].image} 
          name={props.stars[0].name} 
          desc={props.stars[0].desc}
        />

        <p className={styles.section}>Planets</p>
        {props.planets.map(planet => {
          if(planet.type == "Planet") {
            return (
              <ObjectRow 
                as={`/planets/${planet.name}`} 
                href="/planets/[id]" 
                key={`/planets/${planet.name}`} 
                image={planet.image} 
                name={planet.name} 
                desc={planet.desc}
              />
            )
          }
          return null
        })}

        <p className={styles.section}>Dwarf Planets</p>
        {props.planets.map(planet => {
          if(planet.type == "Dwarf Planet") {
            return (
              <ObjectRow 
                as={`/planets/${planet.name}`} 
                href="/planets/[id]" 
                key={`/planets/${planet.name}`} 
                image={planet.image} 
                name={planet.name} 
                desc={planet.desc}
              />
            )
          }
          return null
        })}

        <p className={styles.section}>Moons</p>
        {props.planets.map(planet => {
          if(planet.type == "Planet") {
            let moons = getMoons(planet, props.moons);
            if(moons.length == 1) {
              let moon = moons[0];
              return (
                <ObjectRow 
                  as={`/moons/${moon.name}`} 
                  href="/moons/[id]" 
                  key={`/moons/${moon.name}`} 
                  image={moon.image} 
                  name={moon.name} 
                  desc={moon.desc}
                />
              )
            }
            else if(moons.length > 1) {
              var imageID = 0;
              switch(planet.name) {
                case "Jupiter":
                  imageID = 2;
                  break;
                case "Saturn":
                  imageID = 5;
                  break;
                case "Uranus":
                  imageID = 2;
                  break;
                default:
                  imageID = 0;
              }
              return (    
                <ObjectRow 
                  as={`/moons/moonlist/${planet.name}`} 
                  href="/moons/moonlist/[id]" 
                  key={`/moons/moonlist/${planet.name}`} 
                  image={moons[imageID].image} 
                  name={`${planet.adjective} Moons`} 
                  desc={`${planet.name}'s ${moons.length} Moons`}
                />
              )
            }
          }
          return null
        })}
        <ObjectRow 
          as={`/moons/moonlist/Dwarf`} 
          href="/moons/moonlist/Dwarf" 
          key={`/moons/moonlist/Dwarf`} 
          image={props.moons[205].image} 
          name={`Dwarf Moons`} 
          desc={`Moons of the Dwarf Planets`}
        />

        <p className={styles.section}>Other Objects</p>
        <ObjectRow 
          as={`/objects/Asteroids`} 
          href="/objects/Asteroids" 
          key={`/objects/Asteroids`} 
          image={props.other[3].image} 
          name={`Asteroids`} 
          desc={`Small rocky bodies orbiting the Sun`}
        />
        <ObjectRow 
          as={`/objects/Comets`} 
          href="/objects/Comets" 
          key={`/objects/Comets`} 
          image={props.other[60].image} 
          name={`Comets`} 
          desc={`Small frozen rocky objects orbiting the Sun`}
        />
        <ObjectRow 
          as={`/planets/${props.planets[13].name}`} 
          href="/planets/[id]" 
          key={`/planets/${props.planets[13].name}`} 
          image={props.planets[13].image} 
          name={props.planets[13].name} 
          desc={props.planets[13].desc} 
        />

        <Footer/>
      </Flex>
    </Box>
  )
}

function getMoons(planet, moonList) {
  var moons = [];
  moonList.map(moon => {
    if(moon.orbiting == planet.name) {
      moons.push(moon);
    }
  });
  return moons;
}

export async function getStaticProps({ params }) {
  const json = await fetch("https://raw.githubusercontent.com/joerup2004/planetaria/main/objects1.json");
  const bodies = await json.json();
  const { stars, planets, moons, other } = bodies;

  return {
    props: {
      stars,
      planets,
      moons,
      other,
    }
  };
}
