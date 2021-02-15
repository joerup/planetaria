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
import { getStarSystems, starDesc } from "../../components/helpers.js";

export default function Star({ star, stars, system, properties }) {
  const router = useRouter();
  const { id } = router.query;

  return (
    <>
    <Box className={styles.background}>
      <Head>
        <title>{star.name} | Planetaria</title>
        <meta name="viewport" content="initial-scale=1.0, width=device-width" />
      </Head>
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
                  <p class={styles.objecttitle}>{star.name}</p>
                  <p class={styles.objectdesc}>{starDesc(star)}</p>
                  <p class={styles.objectdesc}>{star.nickname}</p>
                </div>
            </div>

            {star.image != null ? <img class={styles.objectimage} src={`https://github.com/joerup2004/planetaria/blob/main/Images/Objects/${star.image}.png?raw=true`}/> : <></>}

            <p className={styles.paragraph}>{star.paragraph}</p>
            <p className={styles.paragraph2}><Discovery discoveryDate={star.discoveryDate} discoveredBy={star.discoveredBy}/></p>
            <p className={styles.paragraph2}><Namesake namesake={star.namesake} nameReason={star.nameReason}/></p>

          </div>

          <div class={styles.column2}>
            <PropertySection type="star" sectionName="Star Properties" properties={properties}/>
            <PropertyRow name="Spectral Type" data={star.spectralType} unit=""/>
            <PropertyRow name="Color" data={star.color} unit=""/>
            <PropertyRow name="Star Type" data={star.type__1} unit=""/>
            <PropertyRow name="Luminosity" data={star.luminosity} unit=" J/s"/>
            <PropertyRow name="Luminosity" data={star.relativeBolometricLuminosity} unit=" × Sun"/>
            <PropertyRow name="Apparent Magnitude" data={star.apparentMagnitude} unit="" vector="true"/>
            <PropertyRow name="Absolute Magnitude" data={star.absoluteMagnitude} unit="" vector="true"/>

            <PropertySection type="star" sectionName="Position" properties={properties}/>
            <PropertyRow name="Distance" data={star.distanceLy} unit=" ly"/>
            <PropertyRow name="Right Ascension" data={star.rightAscension} unit="º" sf="6"/>
            <PropertyRow name="Declination" data={star.declination} unit="º" sf="6"/>

            <PropertySection type="star" sectionName="Dimensions" properties={properties}/>
            <PropertyRow name="Mass" data={star.mass} unit=" kg"/>
            <PropertyRow name="Mass" data={star.relativeMassUnit == "Ms" ? star.relativeMass : null} unit=" × Sun"/>
            <PropertyRow name="Volume" data={star.volume} unit=" km³"/>
            <PropertyRow name="Mean Radius" data={star.meanRadius} unit=" km"/>
            <PropertyRow name="Mean Radius" data={star.relativeRadiusUnit == "Rs" ? star.relativeRadius : null} unit=" × Sun"/>
            <PropertyRow name="Density" data={star.density != null ? star.density/1000 : null} unit=" g/cm³"/>
            <PropertyRow name="Core Density" data={star.densityCenter != null ? star.densityCenter/1000 : null} unit=" g/cm³"/>

            <PropertySection type="star" sectionName="Rotation" properties={properties}/>
            <PropertyRow name="Rotation Direction" data={star.rotationDirection} unit=""/>
            <PropertyRow name="Rotation Period" data={star.siderealRotation} unit=" hr" cutoff="100" divide="24" unit2=" days" vector="false"/>
            <PropertyRow name="Obliquity to Ecliptic" data={star.obliquityToOrbit} unit="º"/>
            <PropertyRow name="Speed Relative to Stars" data={star.speedRelativeToStars} unit=" km/s"/>

            <PropertySection type="star" sectionName="Orbit" properties={properties}/>
            {/* <PropertyRow name="Orbiting" data={star.orbiting} unit=""/>
            <PropertyRow name="Orbital Radius" data={star.orbitalRadius} unit=" ly"/>
            <PropertyRow name="Orbital Period" data={star.orbitalPeriod} unit=" years"/>
            <PropertyRow name="Orbital Velocity" data={star.orbitalVelocity} unit=" km/s"/> */}
            <PropertyRow name="Orbiting" data={star.binaryOrbiting} unit=""/>
            <PropertyRow name="Orbital Radius" data={star.binaryOrbitalRadius} unit=" AU"/>
            <PropertyRow name="Orbital Period" data={star.binaryOrbitalPeriod} unit=" years"/>

            <PropertySection type="star" sectionName="Surface" properties={properties}/>
            <PropertyRow name="Surface Gravity" data={star.surfaceGravity} unit=" m/s²"/>
            <PropertyRow name="Escape Velocity" data={star.escapeVelocity} unit=" km/s"/>
            <PropertyRow name="Surface Temperature" data={star.tempSurface} unit=" K"/>
            <PropertyRow name="Core Temperature" data={star.tempCenter} unit=" K"/>
            <PropertyRow name="Core Pressure" data={star.pressureCenter != null ? star.pressureCenter*100 : null} unit=" kPa"/>
            <PropertyRow name="Mass Conversion" data={star.massConversionRate} unit=" kg/s"/>
          </div>
        </div>

        <div className={styles.columns}>
          <div className={styles.column1}>
            <p class={styles.nextDesc}>Previous</p>
            {getPrev(star, stars)}
          </div>
          <div className={styles.column2}>
            <p class={styles.nextDesc}>Next</p>
            {getNext(star, stars)}
          </div>
        </div>

        <Footer/>
      </Flex>
    </Box>
    </>
  );
}

function getPrev(current, stars) {
  let id = current.id;
  if(id-2 < 0) return(
    <></>
  )
  let prev = stars[id-2];
  return(
    <ObjectRow 
      as={`/stars/${prev.name}`} 
      href="/stars/[id]" 
      key={`/stars/${prev.name}`} 
      image={prev.image} 
      name={prev.name} 
      desc={prev.desc != null ? prev.desc : starDesc(prev)}
      object="true"
    />
  )
}
function getNext(current, stars) {
  let id = current.id;
  if(id >= stars.length) return(
    <></>
  )
  let next = stars[id];
  return(
    <ObjectRow 
      as={`/stars/${next.name}`} 
      href="/stars/[id]" 
      key={`/stars/${next.name}`} 
      image={next.image} 
      name={next.name} 
      desc={next.desc != null ? next.desc : starDesc(next)}
      object="true"
    />
  )
}

export async function getStaticPaths() {
  const json = await fetch("https://raw.githubusercontent.com/joerup2004/planetaria/main/objects1.json");
  const bodies = await json.json();
  const paths = bodies.stars.map(star => ({
    params: { id: star.name.toString() }
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

  const json2 = await fetch("https://raw.githubusercontent.com/joerup2004/planetaria/main/properties1.json");
  const properties = await json2.json();

  let star = stars.find(star => star.name == params.id);
  let systems = getStarSystems(stars, planets);
  let system = systems.find(system => system.name == star.system);

  return {
    props: {
      star: star,
      stars: stars,
      system: system,
      properties: properties
    }
  };
}