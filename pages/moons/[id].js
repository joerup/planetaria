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
import MoonGroup from '../../components/small/MoonGroup.js';

export default function Moon({ moon, moons, planet, properties }) {
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
                  <p class={styles.objecttitle}>{moon.name}</p>
                  <p class={styles.objectdesc}>{moon.desc}</p>
                  <p class={styles.objectdesc}>{`${moon.orbiting} ${moon.altName3}`}</p>
                </div>
            </div>

            {moon.image != null ? <img class={styles.objectimage} src={`https://github.com/joerup2004/planetaria/blob/main/Images/Objects/${moon.image}.png?raw=true`}/> : <></>}

            <p className={styles.paragraph}>{moon.paragraph}</p>
            <p className={styles.paragraph2}><MoonGroup group={moon.group}/></p>
            <p className={styles.paragraph2}><Discovery discoveryDate={moon.discoveryDate} discoveredBy={moon.discoveredBy}/></p>
            <p className={styles.paragraph2}><Namesake namesake={moon.namesake} nameReason={moon.nameReason}/></p>

          </div>

          <div class={styles.column2}>
            <PropertySection type="moon" sectionName="Orbit" properties={properties}/>
            <PropertyRow name="Orbiting" data={moon.orbiting} unit=""/>
            <PropertyRow name="Orbital Radius" data={moon.orbitalRadius} unit=" km"/>
            <PropertyRow name="Perigee" data={moon.perigee} unit=" km"/>
            <PropertyRow name="Apogee" data={moon.apogee} unit=" km"/>
            <PropertyRow name="Orbital Direction" data={moon.orbitalDirection} unit=""/>
            <PropertyRow name="Orbital Period" data={moon.siderealPeriod} unit=" days" cutoff="1000" divide="365" unit2=" years" cutoff2="100" mult="24" unit3=" hr"/>
            <PropertyRow name="Orbital Velocity" data={moon.orbitalVelocity} unit=" km/s"/>
            <PropertyRow name="Orbital Inclination" data={moon.orbitalInclination} unit="º"/>
            <PropertyRow name="Inclination to Equator" data={moon.equatorInclination} unit="º"/>
            <PropertyRow name="Orbital Eccentricity" data={moon.orbitalEccentricity} unit=""/>

            <PropertySection type="moon" sectionName="Rotation" properties={properties}/>
            <PropertyRow name="Rotation Direction" data={moon.rotationDirection} unit=""/>
            <PropertyRow name="Rotation Period" data={moon.siderealRotation} unit=" hr" cutoff="100" divide="24" unit2=" days" vector="false"/>
            <PropertyRow name="Obliquity to Orbit" data={moon.obliquityToOrbit} unit="º"/>
            <PropertyRow name="Obliquity to Ecliptic" data={moon.obliquityToEcliptic} unit="º"/>
            <PropertyRow name="Recession Rate" data={moon.recessionRate} unit=" cm/year" vector="true"/>

            <PropertySection type="moon" sectionName="Dimensions" properties={properties}/>
            <PropertyRow name="Mass" data={moon.mass} unit=" kg"/>
            <PropertyRow name="Volume" data={moon.volume} unit=" km³"/>
            <PropertyRow name="Mean Radius" data={moon.meanRadius} unit=" km"/>
            <PropertyRow name="Mean Radius" data={(moon.subplanetaryAxisRadius != null && moon.alongOrbitAxisRadius != null && moon.polarAxisRadius != null) ? `${moon.subplanetaryAxisRadius} × ${moon.alongOrbitAxisRadius} × ${moon.polarAxisRadius}` : (moon.subplanetaryAxisRadius != null && moon.polarAxisRadius != null) ? `${moon.subplanetaryAxisRadius} × ${moon.polarAxisRadius}` : null} unit=" km"/>
            <PropertyRow name="Equatorial Radius" data={moon.equatorialRadius} unit=" km"/>
            <PropertyRow name="Polar Radius" data={moon.polarRadius} unit=" km"/>
            <PropertyRow name="Core Radius" data={moon.coreRadius} unit=" km"/>
            <PropertyRow name="Ellipticity" data={moon.ellipticity} unit=""/>
            <PropertyRow name="Density" data={moon.density != null ? moon.density/1000 : null} unit=" g/cm³"/>

            <PropertySection type="moon" sectionName="Surface" properties={properties}/>
            <PropertyRow name="Surface Gravity" data={moon.surfaceGravity} unit=" m/s²"/>
            <PropertyRow name="Escape Velocity" data={moon.escapeVelocity} unit=" km/s"/>
            <PropertyRow name="Temperature" data={moon.avgTemp} unit="ºC"/>
            <PropertyRow name="Pressure" data={moon.surfacePressure != null ? moon.surfacePressure*100 : null} unit=" kPa"/>
            <PropertyRow name="Magnetic Field" data={moon.magneticField == null ? null : moon.magneticField ? "Yes" : "No"} unit=""/>
          </div>
        </div>

        <div className={styles.columns}>
          <div className={styles.column1}>
            <p class={styles.nextDesc}>Previous</p>
            {getPrev(moon, moons)}
          </div>
          <div className={styles.column2}>
            <p class={styles.nextDesc}>Next</p>
            {getNext(moon, moons)}
          </div>
        </div>

        <Footer/>
      </Flex>
    </Box>
    </>
  );
}

function getPrev(current, moons) {
  let id = current.id;
  if(id-2 < 0) return(
    <></>
  )
  let prev = moons[id-2];
  return(
    <ObjectRow 
      as={`/moons/${prev.name}`} 
      href="/moons/[id]" 
      key={`/moons/${prev.name}`} 
      image={prev.image} 
      name={prev.name} 
      desc={prev.altName3 != null ? `${prev.orbiting} ${prev.altName3}` : ''}
    />
  )
}
function getNext(current, moons) {
  let id = current.id;
  if(id >= moons.length) return(
    <></>
  )
  let next = moons[id];
  return(
    <ObjectRow 
      as={`/moons/${next.name}`} 
      href="/moons/[id]" 
      key={`/moons/${next.name}`} 
      image={next.image} 
      name={next.name} 
      desc={next.altName3 != null ? `${next.orbiting} ${next.altName3}` : ''}
    />
  )
}

export async function getStaticPaths() {
  const json = await fetch("https://raw.githubusercontent.com/joerup2004/planetaria/main/objects1.json");
  const bodies = await json.json();
  const paths = bodies.moons.map(moon => ({
    params: { id: moon.name.toString() }
  }));

  return {
    paths,
    fallback: false
  };
}

export async function getStaticProps({ params }) {
  const json = await fetch("https://raw.githubusercontent.com/joerup2004/planetaria/main/objects1.json");
  const bodies = await json.json();
  const { moons, planets } = bodies;

  const json2 = await fetch("https://raw.githubusercontent.com/joerup2004/planetaria/main/properties1.json");
  const properties = await json2.json();

  let moon = moons.find(moon => moon.name == params.id)
  let planet = planets.find(planet => planet.name == moon.orbiting);

  return {
    props: {
      moon: moon,
      moons: moons,
      planet: planet,
      properties: properties
    }
  };
}