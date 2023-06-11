<script>
  export let name
  export let buttonStyle = 'text'
  export let isActive = false
  export let halfWidth = false

  import { createEventDispatcher } from 'svelte'
  const dispatch = createEventDispatcher();
</script>

<button
  class:title={buttonStyle === 'text'}
  class:active={isActive}
  style={halfWidth ? 'width: 47%' : ''}
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
    background: #3ebad0 no-repeat center center / cover;
    color: #fff;
    border-radius: 5px;
    margin-bottom: 0.5rem !important;
  }
  button.active {
    background-color: #e96d86;
  }
  button:not(.title) {
    padding: 0;
    width: 192px;
    height: 126px;
  }
</style>
