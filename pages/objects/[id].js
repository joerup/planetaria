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
import SpectralType from '../../components/small/SpectralType.js';

export default function OtherObject({ object, other, properties }) {
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
                  <p class={styles.objecttitle}>{object.name}</p>
                  <p class={styles.objectdesc}>{object.type == "Asteroid" ? "Asteroid #"+object.asteroidNumber : "Comet "+object.cometNumber}</p>
                  <p class={styles.objectdesc}>{object.nickname}</p>
                </div>
            </div>

            {object.image != null ? <img class={styles.objectimage} src={`https://github.com/joerup2004/planetaria/blob/main/Images/Objects/${object.image}.png?raw=true`}/> : <></>}

            <p className={styles.paragraph}>{object.paragraph}</p>
            <p className={styles.paragraph2}><Discovery discoveryDate={object.discoveryDate} discoveredBy={object.discoveredBy}/></p>
            <p className={styles.paragraph2}><Namesake namesake={object.namesake} nameReason={object.nameReason}/></p>
            <p className={styles.paragraph2}><SpectralType type={object.spectralClass}/></p>

          </div>

          <div class={styles.column2}>
            <PropertySection type="object" sectionName="Orbit" properties={properties}/>
            <PropertyRow name="Orbiting" data={object.orbiting} unit=""/>
            <PropertyRow name="Orbital Radius" data={object.orbitalRadiusAU} unit=" AU"/>
            <PropertyRow name="Perihelion" data={object.perihelionAU} unit=" AU"/>
            <PropertyRow name="Orbital Period" data={object.siderealPeriod} unit=" years"/>
            <PropertyRow name="Orbital Inclination" data={object.orbitalInclination} unit="º"/>
            <PropertyRow name="Orbital Eccentricity" data={object.orbitalEccentricity} unit=""/>

            <PropertySection type="object" sectionName="Rotation" properties={properties}/>
            <PropertyRow name="Rotation Period" data={object.siderealRotation} unit=" hr" cutoff="100" divide="24" unit2=" days" vector="false"/>

            <PropertySection type="object" sectionName="Dimensions" properties={properties}/>
            <PropertyRow name="Mass" data={object.massE15 != null ? object.massE15*Math.pow(10,15) : null} unit=" kg"/>
            <PropertyRow name="Diameter" data={object.diameter} unit=" km"/>
            <PropertyRow name="Size" data={(object.dimensionX != null && object.dimensionY != null && object.dimensionZ != null) ? `${object.dimensionX} × ${object.dimensionY} × ${object.dimensionZ}` : (object.dimensionX != null && object.dimensionY != null) ? `${object.dimensionX} × ${object.dimensionY}` : null} unit=" km"/>
          </div>
        </div>

        <div className={styles.columns}>
          <div className={styles.column1}>
            <p class={styles.nextDesc}>Previous</p>
            {getPrev(object, other)}
          </div>
          <div className={styles.column2}>
            <p class={styles.nextDesc}>Next</p>
            {getNext(object, other)}
          </div>
        </div>

        <Footer/>
      </Flex>
    </Box>
    </>
  );
}

function getPrev(current, other) {
  let id = current.id;
  if(id-2 < 1) return(
    <></>
  )
  let prev = other[id-2];
  return(
    <ObjectRow 
      as={`/objects/${prev.name}`} 
      href="/objects/[id]" 
      key={`/objects/${prev.name}`} 
      image={prev.image} 
      name={prev.name} 
      desc={prev.asteroidNumber != null ? `Asteroid #${prev.asteroidNumber}` : prev.cometNumber != null ? `Comet ${prev.cometNumber}` : prev.desc} 
    />
  )
}
function getNext(current, other) {
  let id = current.id;
  if(id >= other.length) return(
    <></>
  )
  let next = other[id];
  return(
    <ObjectRow 
      as={`/objects/${next.name}`} 
      href="/objects/[id]" 
      key={`/objects/${next.name}`} 
      image={next.image} 
      name={next.name} 
      desc={next.asteroidNumber != null ? `Asteroid #${next.asteroidNumber}` : next.cometNumber != null ? `Comet ${next.cometNumber}` : next.desc} 
    />
  )
}


export async function getStaticPaths() {
  const json = await fetch("https://raw.githubusercontent.com/joerup2004/planetaria/main/objects.json");
  const bodies = await json.json();
  const paths = bodies.other.map(object => ({
    params: { id: object.name.toString() }
  }));

  return {
    paths,
    fallback: false
  };
}

export async function getStaticProps({ params }) {
  const json = await fetch("https://raw.githubusercontent.com/joerup2004/planetaria/main/objects.json");
  const bodies = await json.json();
  const { other } = bodies;

  const json2 = await fetch("https://raw.githubusercontent.com/joerup2004/planetaria/main/properties.json");
  const properties = await json2.json();

  return {
    props: {
      object: other.find(object => object.name == params.id),
      other: other,
      properties: properties
    }
  };
}