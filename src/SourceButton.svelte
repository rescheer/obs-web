<script>
  export let name
  export let buttonStyle = 'text'
  export let icon = '#ffffff'
  export let isProgram = false
  export let isPreview = false
  export let activeSingle
  export let img = ''

  const isSingleScene = name.includes('Duo')
  const isMetaScene = name.includes('META')
  let subName = name.substr(5)

  if (name.includes('Duo')) {
    subName = 'Single'
  } else if (name.includes('Focus')) {
    subName = 'Dice Box'
  }

  import { createEventDispatcher } from 'svelte'
  const dispatch = createEventDispatcher()

  $: style = icon.startsWith('#')
    ? `background-color: ${icon};`
    : `background-image: url(${icon});`
</script>

<button
  class:title={buttonStyle === 'text'}
  class:program={isProgram}
  class:preview={isPreview}
  class:meta={isMetaScene}
  class:taylor={isSingleScene && activeSingle === 'taylor'}
  class:kitty={isSingleScene && activeSingle === 'kitty'}
  class:sam={isSingleScene && activeSingle === 'sam'}
  class:josh={isSingleScene && activeSingle === 'josh'}
  class:with-icon={buttonStyle === 'icon'}
  on:click={() => dispatch('click')}
  style={buttonStyle === 'icon' ? style : ''}
  title={subName}
  >
  {#if img}<img src={img} alt={subName} class="thumbnail" />{/if}
  {#if buttonStyle !== 'icon'}{subName}{/if}
</button>

<style>
  button {
    border: none;
    height: 3.5rem;
    text-align: center;
    font-size: 1.25rem;
    width: 100%;
    cursor: pointer;
    background: #3e8ed0 no-repeat center center / cover;
    color: #fff;
    border-radius: 5px;
  }
  button.meta {
    background: #275b86 no-repeat center center / cover;
  }
  button.taylor::after {
    content: " - Taylor"
  }
  button.kitty::after {
    content: " - Kitty"
  }
  button.sam::after {
    content: " - Sam"
  }
  button.josh::after {
    content: " - Josh"
  }
  button.preview {
    background-color: #00d1b2;
  }
  button.program {
    background-color: #f14668;
  }
  button:not(.title) {
    padding: 0;
    width: 192px;
    height: 126px;
  }
  button.with-icon {
    height: 64px;
    width: 64px;
    box-shadow: 2px 2px 5px gray;
    margin: .5em;
    border-radius: 5px;
    cursor: pointer;
    background: white no-repeat center center / cover;
    position: relative;
  }
  button.with-icon.program::before {
    content: " ";
    position: absolute;
    top: -5px;
    right: -5px;
    background: red;
    width: 12px;
    height: 12px;
    border-radius: 50%;
    box-shadow: 1px 1px 5px gray;
  }
  .thumbnail {
    display: block;
    max-width: 100%;
    max-height: calc(100% - 1rem);
    margin: 0 auto;
  }
</style>
