import {CharacterData} from "./character_data";

interface Text extends CharacterData {
  new(value?: string): Text;
}
