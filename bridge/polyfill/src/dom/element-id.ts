import { Element } from "./element";

export const elementMapById: {
  [key: string]: {
    element: any;
    elementList: any[];
  }
} = {};

export function removeElementById(elementId: string, element: Element): void {
  const mapEntity = elementMapById[elementId];
  if (mapEntity && mapEntity.elementList) {
    if (mapEntity.elementList.length === 0) {
      delete elementMapById[elementId];
    } else {
      mapEntity.elementList = mapEntity.elementList.filter((item: Element) => item !== element);
      if (mapEntity.elementList.length === 1) {
        [mapEntity.element] = mapEntity.elementList;
        mapEntity.elementList = [];
      }
    }
  }
}

export function addElementById(elementId: string, element: Element): void {
  const mapEntity = elementMapById[elementId];
  if (mapEntity) {
    if (mapEntity.elementList.length > 0) {
      mapEntity.elementList.push(element);
    } else {
      mapEntity.elementList = [element, mapEntity.element];
      mapEntity.element = null;
    }
  } else {
    const newEntity = { element, elementList: [] };
    elementMapById[elementId] = newEntity;
  }
}
