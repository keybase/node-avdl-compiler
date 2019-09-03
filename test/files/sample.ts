/*
 * sample.1
 * SampleInterface protocol is a sample among samples.
 *
 * Auto-generated to TypeScript types by avdl-compiler v1.4.1 (https://github.com/keybase/node-avdl-compiler)
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

export type Boozle = { typ: Types.BOZO, BOZO: number | null } | { typ: Types.BIPPY, BIPPY: string | null } | { typ: Types.AGGLE, AGGLE: number[] | null } | { typ: Types.FLAGGLE, FLAGGLE: boolean[] | null }

export type Trixie = { typ: Types.NONE } | { typ: Types.BOZO } | { typ: Types.BIPPY, BIPPY: number | null } | { typ: Types.AGGLE } | { typ: Types.FLAGGLE, FLAGGLE: EnumNoString | null }

export type Noozle = { version: int.1, 1: string | null } | { version: int.2, 2: number | null }

export type Blurp = { b: boolean.true, true: string | null } | { b: boolean.false, false: number | null }

export type Simple = {
  s?: Blurp
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