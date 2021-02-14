import React from 'react'

export function getMoons(planet, moonList) {
  var moons = [];
  moonList.map(moon => {
    if(moon.orbiting == planet.name) {
      moons.push(moon);
    }
  });
  return moons;
}

export function getStarSystems(stars, planets) {
  var starSystems = [];
  var systemNames = [];
  var systemID = 0;

  stars.map(star => {
    let system = star.system;

    if(systemNames.includes(system)) {
      for(var i = 0; i < starSystems.length; i++) {
        if(starSystems[i].name == system) {
          starSystems[i].stars.push(star);
          starSystems[i].desc = systemDesc(starSystems[i]);
          break;
        }
      }
    }
    else {
      systemNames.push(system);

      let starSystem = {
        id: systemID,
        name: system,
        type: "Star System",
        desc: starDesc(star),
        stars: [star],
        planets: [],
      }
      systemID++;

      starSystems.push(starSystem);
    }
  })

  planets.map(planet => {
    let system = planet.system;

    for(var i = 0; i < starSystems.length; i++) {
      if(starSystems[i].name == system) {
        starSystems[i].planets.push(planet);
        starSystems[i].desc = systemDesc(starSystems[i]);
        break;
      }
    }
  })

  return starSystems;
}

export function starDesc(star) {
  if(star.desc != null) {
    return star.desc;
  }

  var desc = "";
  if(star.color != "Brown" && (star.color != "Red" || star.type__1 != "Red Dwarf") && (star.color != "White" || star.type__1 != "White Dwarf") && star.type__1 != null && star.color != null) {
    desc = star.color + " " + star.type__1;
  }
  else if(star.type__1 == null) {
    desc = "";
  }
  else {
    desc = star.type__1;
  }

  if(star.constellation != null) {
    desc += ` Star in ${star.constellation}`;
  }
  else {
    desc += " Star"
  }

  return desc;
}

export function systemDesc(system) {
  var desc = ""
  switch(system.stars.length) {
    case 2:
      desc = "Binary";
      break;
    case 3:
      desc = "Triple";
      break;
    case 4:
      desc = "Quadrouple";
      break;
    case 5:
      desc = "Quintuple";
      break;
    case 6:
      desc = "Sextuple";
      break;
    case 1: 
      let star = system.stars[0];
      if(!["White","Brown"].includes(star.color) && (star.color != "Red" || star.type__1 != "Red Dwarf") && star.type__1 != null) {
        desc = star.color + " " + star.type__1;
      }
      else if(star.type__1 == null) {
        desc = "";
      }
      else {
        desc = star.type__1;
      }
      break;
    default:
      break;
  }
  desc += " Star System";
  if(system.stars[0].constellation != null) {
    desc += ` in ${system.stars[0].constellation}`
  }
  return desc;
}