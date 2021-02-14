import { useRouter } from "next/router";
import React from 'react'
import { default as NextLink } from 'next/link'
import { Link, Flex, Box, Heading, BreadcrumbLink } from "@chakra-ui/core";
import styles from '../styles/object.module.css'

export default function PropertySection({ type, sectionName, properties }) {
  const router = useRouter();
  const { id } = router.query;

  return (

    <div class={styles.propertySection}>
      <div className={styles.propertySectionName}>
        {sectionName}
      </div>

      <div className={styles.dropdown}>
        <div className={styles.helpButton}>
          <p>?</p>
        </div>
        <div className={styles.dropdowncontent}>
          <h1>{sectionName} of a {type == "object" ? "Small Object" : type[0].toUpperCase() + type.substring(1)}</h1> 
          {getData(type, sectionName, properties).map(item => {
            return(
              <div>
                <h2>{item.name}</h2>
                <p>{item.desc}</p>
              </div>
            )
          })}
          <br/>
        </div>
      </div>
    </div>
  )
}

function getData(type, section, properties) {

  var collection = properties.objectDesc;
  if(type == "star") {
    collection = properties.starDesc;
  }
  else if(type == "planet") {
    collection = properties.planetDesc;
  }
  else if(type == "moon") {
    collection = properties.moonDesc;
  }
  else if(type == "object") {
    collection = properties.objectDesc;
  }

  if(section == "Orbit") {
    return collection.orbit;
  }
  else if(section == "Rotation") {
    return collection.rotation;
  }
  else if(section == "Dimensions") {
    return collection.dimensions;
  }
  else if(section == "Surface") {
    return collection.surface;
  }
  else if(section == "Star Properties") {
    return collection.starProperties;
  }
  else if(section == "Position") {
    return collection.position;
  }
  else if(section == "Moons") {
    return collection.moons;
  }

  return collection.orbit;
}
