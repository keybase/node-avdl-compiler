/*
 * sample.1
 * SampleInterface protocol is a sample among samples.
 *
 * Auto-generated to TypeScript types by avdl-compiler v1.4.9 (https://github.com/keybase/node-avdl-compiler)
 * Input files:
 * - avdl/sample.avdl
 */

import * as keybase1 from 'github.com/keybase/client/go/protocol/keybase1'

/**
 * Joe is an alias for an int.
 */
export type Joe = number

/**
 * R is a rad record.
 */
export type R = {
  bar: keybase1.UID
  bazJUid: keybase1.UID
  woop?: string
}

export enum Types {
  NONE = 'none',
  BOZO = 'bozo',
  BIPPY = 'bippy',
  AGGLE = 'aggle',
  FLAGGLE = 'flaggle',
}

export enum EnumNoString {
  NOSTRING = 'nostring',
}

export type Boozle = { typ: Types.BOZO, 'BOZO': number } | { typ: Types.BIPPY, 'BIPPY': string } | { typ: Types.AGGLE, 'AGGLE': number[] } | { typ: Types.FLAGGLE, 'FLAGGLE': boolean[] } | { typ: Exclude<Types, Types.BOZO | Types.BIPPY | Types.AGGLE | Types.FLAGGLE> }

export type Trixie = { typ: Types.NONE } | { typ: Types.BOZO } | { typ: Types.BIPPY, 'BIPPY': number } | { typ: Types.AGGLE } | { typ: Types.FLAGGLE, 'FLAGGLE': EnumNoString } | { typ: Exclude<Types, Types.NONE | Types.BOZO | Types.BIPPY | Types.AGGLE | Types.FLAGGLE> }

export type Noozle = { version: 1, '1': string } | { version: 2, '2': number } | { version: Exclude<int, int.1 | int.2> }

export type Blurp = { b: true, 'true': string } | { b: false, 'false': number } | { b: Exclude<boolean, boolean.true | boolean.false> }

export type Simple = {
  s?: Blurp
  t?: Blurp | null
  u?: Blurp[] | null
}

export type Hash = Buffer

export type Cat = {
  bird: {[key: string]: Noozle}
  bee: {[key: string]: Noozle}
  birds: {[key: string]: Noozle[] | null}
  pickles: {[key: string]: number}
  penny: {[key: string]: number}
  pa: {[key: string]: string}
  wow: {[key: string]: Noozle[] | null}[] | null
  boo: Buffer
  hooHah: Hash
  seqno: rpc.SeqNumber
}

export type messageID = number

export type BigBytes = string | null
export enum TeamInviteCategory {
  NONE = 'none',
  UNKNOWN = 'unknown',
  KEYBASE = 'keybase',
  EMAIL = 'email',
  SBS = 'sbs',
  SEITAN = 'seitan',
  PHONE = 'phone',
}

export type TeamInviteType = { c: TeamInviteCategory.UNKNOWN, 'UNKNOWN': string } | { c: TeamInviteCategory.SBS, 'SBS': number } | { c: Exclude<TeamInviteCategory, TeamInviteCategory.UNKNOWN | TeamInviteCategory.SBS> }
