import { Element } from "../element";

export const elementMapById = {};

export function removeElementById(elementid: string, element: Element): void {
  const mapEntity = elementMapById[elementid];
  if (mapEntity && mapEntity.elementList) {
    if (mapEntity.elementList.length === 0) {
      delete elementMapById[elementid];
    } else {
      mapEntity.elementList = mapEntity.elementList.filter((item: Element) => item !== element);
      if (mapEntity.elementList.length === 1) {
        [mapEntity.element] = mapEntity.elementList;
        mapEntity.elementList = [];
      }
    }
  }
}

export function addElementById(elementid: string, element: Element): void {
  const mapEntity = elementMapById[elementid];
  if (mapEntity) {
    if (mapEntity.elementList.length > 0) {
      mapEntity.elementList.push(element);
    } else {
      mapEntity.elementList = [element, mapEntity.element];
      mapEntity.element = null;
    }
  } else {
    const newEntity = { element, elementList: [] };
    elementMapById[elementid] = newEntity;
  }
}
