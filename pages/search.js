import React from 'react';
import NextLink from "next/link";
import { Link, Flex, Box, Heading } from "@chakra-ui/core";
import { NextPage } from "next";
import styles from '../styles/list.module.css';
import Header from '../components/Header.js';
import Footer from '../components/Footer.js';
import ObjectRow from '../components/ObjectRow.js';
import { getStarSystems, starDesc, systemDesc } from "../components/helpers.js";

class SearchBar extends React.Component {
  constructor(props) {
    super(props);
    this.state = {value: ''};

    this.systems = props.systems; 
    this.stars = props.stars;
    this.planets = props.planets;
    this.moons = props.moons;
    this.other = props.other;

    this.handleChange = this.handleChange.bind(this);
  }

  handleChange(event) {
    this.setState({value: event.target.value});
  }

  searchAllObjects(objects) {
    var results = [];
    var id = [];

    if(objects == null) return results;
    if(this.state.value.length <= 2) return results;

    objects.map(object => {

      var desc = ""
      if(object.desc != null) {
        desc = object.desc
      }
      else if(object.type == "Star") {
        desc = starDesc(object)
      }

      var name = object.name;
      if(name == "Ceres" && object.type != "Dwarf Planet") name = "";

      if(name.toUpperCase() == this.state.value.toUpperCase() && !id.includes(object.id)) {
        results.push(object);
        id.push(object.id);
      }
      else if(name.toUpperCase().startsWith(this.state.value.toUpperCase()) && !id.includes(object.id)) {
        results.push(object);
        id.push(object.id);
      }
      else if(name.toUpperCase().includes(this.state.value.toUpperCase()) && !id.includes(object.id)) {
        results.push(object);
        id.push(object.id);
      }
      else if(desc.toUpperCase().includes(this.state.value.toUpperCase()) && !id.includes(object.id)) {
        results.push(object);
        id.push(object.id);
      }
    })
    return results;
  }

  render() {
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
                <label>
                  <input type="text" className={styles.searchBar} value={this.state.value} onChange={this.handleChange}/>
                  <p className={styles.searchDesc}> 
                    Search for names or keywords for stars, planets, moons, or other objects
                  </p>
                </label>
              </div>
            </div>
          </div>

          {this.searchAllObjects(this.systems).map(system => {
            if(system.stars.length > 1 || system.planets.length > 0 && system.name != "Solar System") {
              return (
                <ObjectRow 
                  as={`/systems/${system.name}`} 
                  href={`/systems/[id]`}
                  key={`/systems/${system.name}`} 
                  image={system.stars[0].image} 
                  name={system.name} 
                  desc={system.desc != null ? system.desc : systemDesc(system)}
                />
              )
            }
          })}

          {this.searchAllObjects(this.stars).map(star => {
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

          {this.searchAllObjects(this.planets).map(planet => {
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

          {this.searchAllObjects(this.moons).map(moon => {
            return (
              <ObjectRow 
                as={`/moons/${moon.name}`} 
                href={`/moons/[id]`}
                key={`/moons/${moon.name}`} 
                image={moon.image} 
                name={moon.name} 
                desc={moon.desc}
              />
            )
          })}

          {this.searchAllObjects(this.other).map(object => {
            return (
              <ObjectRow 
                as={`/objects/${object.name}`} 
                href={`/objects/[id]`}
                key={`/objects/${object.name}`} 
                image={object.image} 
                name={object.name} 
                desc={object.desc}
              />
            )
          })}

          <Footer/>
        </Flex>
      </Box>
    );
  }
}

export default function Search(props) {
  return (
    <SearchBar systems={props.systems} stars={props.stars} planets={props.planets} moons={props.moons} other={props.other}/>
  )
}

export async function getStaticProps({ params }) {
  const json = await fetch("https://raw.githubusercontent.com/joerup2004/planetaria/main/objects1.json");
  const bodies = await json.json();
  const { stars, planets, moons, other } = bodies;

  const systems = getStarSystems(stars, planets);

  return {
    props: {
      systems,
      stars,
      planets,
      moons,
      other
    }
  };
}



