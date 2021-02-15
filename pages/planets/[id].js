import { useRouter } from "next/router";
import NextLink from "next/link";
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import Head from "next/head";
import styles from '../../styles/object.module.css';
import Header from '../../components/Header.js';
import Footer from '../../components/Footer.js';
import ObjectRow from '../../components/ObjectRow.js';
import PropertyRow from '../../components/PropertyRow.js';
import PropertySection from '../../components/PropertySection.js';
import Namesake from '../../components/small/Namesake.js';
import Discovery from '../../components/small/Discovery.js';
import { getMoons, getStarSystems } from "../../components/helpers.js";

export default function Planet({ planet, planets, moons, system, properties }) {
  const router = useRouter();
  const { id } = router.query;

  return (
    <>
    <Box className={styles.background}>
      <Flex flexDirection="column" alignItems="center">
        <Header/>
        <br/><br/><br/><br/>

        <div class={styles.columns}>
          <div class={styles.column1}>

            <div class={styles.headline}>
              <Link href="javascript:history.back()">
                  <img src="https://github.com/joerup2004/planetaria/blob/main/Images/whitechevron.png?raw=true" width="100" height="100"/>
                </Link>
                <div class={styles.headlinetext}>
                  <p class={styles.objecttitle}>{planet.name}</p>
                  <p class={styles.objectdesc}>{planet.desc}</p>
                  <p class={styles.objectdesc}>{planet.nickname}</p>
                </div>
            </div>

            {planet.image != null ? <img class={styles.objectimage} src={`https://github.com/joerup2004/planetaria/blob/main/Images/Objects/${planet.image}.png?raw=true`}/> : <></>}

            <p className={styles.paragraph}>{planet.paragraph}</p>
            <p className={styles.paragraph2}><Discovery discoveryDate={planet.discoveryDate} discoveredBy={planet.discoveredBy}/></p>
            <p className={styles.paragraph2}><Namesake namesake={planet.namesake} nameReason={planet.nameReason}/></p>

          </div>

          <div class={styles.column2}>
            <PropertySection type="planet" sectionName="Orbit" properties={properties}/>
            <PropertyRow name="Orbiting" data={planet.orbiting} unit=""/>
            <PropertyRow name="Orbital Radius" data={planet.orbitalRadiusAU} unit=" AU"/>
            <PropertyRow name="Perihelion" data={planet.perihelionAU} unit=" AU"/>
            <PropertyRow name="Aphelion" data={planet.aphelionAU} unit=" AU"/>
            <PropertyRow name="Orbital Period" data={planet.siderealPeriod} unit=" days" cutoff="1000" divide="365" unit2=" years"/>
            <PropertyRow name="Orbital Velocity" data={planet.orbitalVelocity} unit=" km/s"/>
            <PropertyRow name="Orbital Inclination" data={planet.orbitalInclination} unit="º"/>
            <PropertyRow name="Orbital Eccentricity" data={planet.orbitalEccentricity} unit=""/>

            <PropertySection type="planet" sectionName="Rotation" properties={properties}/>
            <PropertyRow name="Rotation Direction" data={planet.rotationDirection} unit=""/>
            <PropertyRow name="Rotation Period" data={planet.siderealRotation} unit=" hr" cutoff="100" divide="24" unit2=" days" vector="false"/>
            <PropertyRow name="Length of Day" data={planet.dayLength} unit=" hr" cutoff="100" divide="24" unit2=" days"/>
            <PropertyRow name="Obliquity to Orbit" data={planet.obliquityToOrbit} unit="º"/>

            <PropertySection type="planet" sectionName="Dimensions" properties={properties}/>
            <PropertyRow name="Mass" data={planet.mass} unit=" kg"/>
            <PropertyRow name="Volume" data={planet.volume} unit=" km³"/>
            <PropertyRow name="Mean Radius" data={planet.meanRadius} unit=" km"/>
            <PropertyRow name="Equatorial Radius" data={planet.equatorialRadius} unit=" km"/>
            <PropertyRow name="Polar Radius" data={planet.polarRadius} unit=" km"/>
            <PropertyRow name="Core Radius" data={planet.coreRadius} unit=" km"/>
            <PropertyRow name="Ellipticity" data={planet.ellipticity} unit=""/>
            <PropertyRow name="Density" data={planet.density != null ? planet.density/1000 : null} unit=" g/cm³"/>

            <PropertySection type="planet" sectionName="Surface" properties={properties}/>
            <PropertyRow name="Surface Gravity" data={planet.surfaceGravity} unit=" m/s²"/>
            <PropertyRow name="Escape Velocity" data={planet.escapeVelocity} unit=" km/s"/>
            <PropertyRow name="Temperature" data={planet.avgTemp} unit="ºC"/>
            <PropertyRow name="Pressure" data={planet.surfacePressure != null ? planet.surfacePressure*100 : null} unit=" kPa"/>
            <PropertyRow name="Magnetic Field" data={planet.magneticField == null ? null : planet.magneticField ? "Yes" : "No"} unit=""/>
            
            {planet.moons > 0 ?
              <PropertySection type="planet" sectionName="Moons" properties={properties}/> : <></>
            }
            {getMoons(planet, moons).slice(0,4).map(moon => {
              return (
                <ObjectRow 
                  as={`/moons/${moon.name}`} 
                  href="/moons/[id]" 
                  key={`/moons/${moon.name}`} 
                  image={moon.image} 
                  name={moon.name} 
                  desc={moon.altName3 != null ? `${moon.orbiting} ${moon.altName3}` : ''}
                  object="true"
                />
              )
            })}
            {
              planet.moons > 4 ?
              <NextLink 
                as={`/moons/moonlist/${planet.name}`}
                href={`/moons/moonlist/[id]`}
                passHref
                key={`/moons/moonlist/${planet.name}`}
              >
                <Link>
                  <p className={styles.allmoonlink}>All {planet.moons} Moons of {planet.name}</p>
                </Link>
              </NextLink> : <></>
            }
          </div>
        </div>

        <div className={styles.columns}>
          <div className={styles.column1}>
            <p class={styles.nextDesc}>Previous</p>
            {getPrev(planet, planets)}
          </div>
          <div className={styles.column2}>
            <p class={styles.nextDesc}>Next</p>
            {getNext(planet, planets)}
          </div>
        </div>

        <Footer/>
      </Flex>
    </Box>
    </>
  );
}

function getPrev(current, planets) {
  let id = current.id;
  if(id-2 < 0) return(
    <></>
  )
  let prev = planets[id-2];
  return(
    <ObjectRow 
      as={`/planets/${prev.name}`} 
      href="/planets/[id]" 
      key={`/planets/${prev.name}`} 
      image={prev.image} 
      name={prev.name} 
      desc={prev.desc}
      object="true"
    />
  )
}

function getNext(current, planets) {
  let id = current.id;
  if(id >= planets.length) return(
    <></>
  )
  let next = planets[id];
  return(
    <ObjectRow 
      as={`/planets/${next.name}`} 
      href="/planets/[id]" 
      key={`/planets/${next.name}`} 
      image={next.image} 
      name={next.name} 
      desc={next.desc}
      object="true"
    />
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
  const { planets, moons, stars } = bodies;

  const json2 = await fetch("https://raw.githubusercontent.com/joerup2004/planetaria/main/properties1.json");
  const properties = await json2.json();

  let starSystems = getStarSystems(stars, planets);
  let planet = planets.find(planet => planet.name == params.id);
  let system = starSystems.find(system => system.name == planet.system);

  return {
    props: {
      planet: planet,
      planets: planets,
      moons: moons,
      system: system,
      properties: properties
    }
  };
}