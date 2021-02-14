import { useRouter } from "next/router";
import NextLink from "next/link";
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import { NextPage } from "next";
import styles from '../../styles/list.module.css'
import Header from '../../components/Header.js';
import Footer from '../../components/Footer.js';
import ObjectRow from '../../components/ObjectRow.js';

export default function Comets({ comets }) {
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
                <div class={styles.bigobjecttitle}>Comets</div>
                <p class={styles.bigobjectdesc}>Small frozen rocky objects orbiting the Sun</p>
              </div>
              <img className={styles.bigobjectimage} src={`https://github.com/joerup2004/planetaria/blob/main/Images/Objects/${comets[0].image}.png?raw=true`}/>
            </div>
            <p class={styles.paragraph}>Comets are small objects made of ice and dust that originate from the outer Solar System. Some have very eccentric orbits which causes them to approach the Sun at a point in their orbit before being flung back out into the Oort Cloud. Comets with orbital periods less than 200 years are called short-period comets, and the rest are called long-period comets. Comets are known for their bright tails, which result from the sublimation of ice as they approach the Sun. Comets are sources of water and could have even been the source of life on Earth.</p>
          </div>
        </div>

        {comets.map(comet => {
          return (
            <ObjectRow 
              as={`/objects/${comet.name}`} 
              href="/objects/[id]" 
              key={`/objects/${comet.name}`} 
              image={comet.image} 
              name={comet.name} 
              desc={comet.cometNumber} 
            />
          )
        })}
        <Footer/>
      </Flex>
    </Box>
  )
}

export async function getStaticProps({ params }) {
  const json = await fetch("https://raw.githubusercontent.com/joerup2004/planetaria/main/objects.json");
  const bodies = await json.json();
  const { other } = bodies;

  var comets = [];
  other.map(object => {
    if(object.type == "Comet") {
      comets.push(object);
    }
  })

  return {
    props: {
      comets: comets
    }
  };
}