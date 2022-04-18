import {CharacterData} from "./character_data";

export interface Comment extends CharacterData {
  new(): Comment;
}
