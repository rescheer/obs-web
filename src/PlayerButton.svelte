<script>
  export let name
  export let buttonStyle = 'text'
  export let isActive = false
  export let fullWidth = false

  import { createEventDispatcher } from 'svelte'
  const dispatch = createEventDispatcher();
</script>

<button
  class:title={buttonStyle === 'text'}
  class:active={isActive}
  style={fullWidth ? 'width: 100%' : ''}
  on:click={() => dispatch('click')}
  title={name}
  >
  {name}
</button>

<style>
  button {
    border: none;
    height: 3rem;
    text-align: center;
    font-size: 1rem;
    width: 22.5%;
    cursor: pointer;
    background: #3e8ed0 no-repeat center center / cover;
    color: #fff;
    border-radius: 5px;
    margin-bottom: 0.1rem;
  }
  button.active {
    background-color: #f14668;
  }
  button:not(.title) {
    padding: 0;
    width: 192px;
    height: 126px;
  }
</style>
